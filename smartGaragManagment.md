# Stock Management System - Models Relationship Documentation

## System Overview

This motorcycle parts stock management system uses Firebase Firestore as the backend database. Below is a comprehensive guide to understanding how all models relate to each other.

---

## Database Collections Structure

```
firestore/
├── users/               (AppUser)
├── brands/              (Brand)
├── moto_models/         (MotoModel)
├── suppliers/           (Supplier)
├── categories/          (Category - to be created)
├── bike_parts/          (BikePart)
├── stock_transactions/  (StockTransaction - to be created)
└── orders/              (Order - to be created)
    └── order_items/     (subcollection)
```

---

## Core Models and Their Relationships

### 1. **BikePart** (Central Entity)

The `BikePart` is the heart of the system. It connects to multiple other entities:

**Fields:**

- `id` - Unique identifier
- `ref` - Part reference/SKU number
- `name` - Part name
- `category` - Category name/ID
- `brandId` → **references Brand.id**
- `modelId` → **references MotoModel.id**
- `supplierId` → **references Supplier.id**
- `stock` - Current quantity
- `purchasePrice` - Cost from supplier
- `salePrice` - Selling price
- `minThreshold` - Minimum stock level

**Relationships:**

```
BikePart ──┬─→ Brand (many-to-one)
           ├─→ MotoModel (many-to-one)
           ├─→ Supplier (many-to-one)
           └─→ Category (many-to-one)
```

**Example:**

```
Part: "Front Brake Pad"
├─ Brand: "Yamaha"
├─ Model: "YZF-R15"
├─ Supplier: "Moto Parts Tunisia"
└─ Category: "Brakes"
```

---

### 2. **Brand**

Represents motorcycle manufacturers (Yamaha, Honda, Suzuki, etc.)

**Fields:**

- `id` - Unique identifier
- `name` - Brand name (e.g., "Yamaha")
- `logoUrl` - Brand logo image
- `isActive` - Active status

**Relationships:**

```
Brand ←──── BikePart (one-to-many)
      └──── MotoModel (one-to-many)
```

**Usage:**

- One brand has many motorcycle models
- One brand has many parts
- Filter parts by brand: "Show all Yamaha parts"

---

### 3. **MotoModel**

Specific motorcycle models (YZF-R15, CBR150R, etc.)

**Fields:**

- `id` - Unique identifier
- `name` - Model name (e.g., "YZF-R15")
- `brandId` → **references Brand.id**
- `year` - Model year
- `engineCapacity` - CC (e.g., 155cc)

**Relationships:**

```
MotoModel ─→ Brand (many-to-one)
          ←─ BikePart (one-to-many)
```

**Example:**

```
Brand: "Yamaha"
└─ Models:
   ├─ "YZF-R15" (155cc)
   ├─ "MT-15" (155cc)
   └─ "Aerox 155" (155cc)
```

---

### 4. **Supplier**

Vendors who provide motorcycle parts

**Fields:**

- `id` - Unique identifier
- `name` - Supplier contact name
- `company` - Company name
- `phone`, `email` - Contact information
- `totalOrders` - Number of purchases
- `totalSpent` - Total amount spent
- `rating` - Performance rating (0-5)

**Relationships:**

```
Supplier ←──── BikePart (one-to-many)
         └──── PurchaseOrder (one-to-many) [future]
```

**Usage:**

- Track which supplier provides each part
- Compare supplier performance
- Reorder parts from preferred suppliers

---

### 5. **AppUser**

System users (admin, staff, managers)

**Fields:**

- `id` - Unique identifier (Firebase Auth UID)
- `email` - User email
- `displayName` - User's full name
- `role` - User role (admin, staff, viewer)
- `createdAt` - Registration date

**Relationships:**

```
AppUser ←──── StockTransaction (one-to-many)
        └──── Order (one-to-many)
```

**Usage:**

- Track who added/removed stock
- Track who created orders
- Role-based access control

---

## Additional Models to Create

### 6. **Category** (Recommended)

Part categories for better organization

**Suggested Fields:**

```dart
class Category {
  final String id;
  final String name;          // "Engine", "Brakes", "Electrical"
  final String? icon;         // Icon name for UI
  final String? description;
  final int partsCount;       // Number of parts in category
  final bool isActive;
}
```

**Relationships:**

```
Category ←──── BikePart (one-to-many)
```

**Example Categories:**

- Engine Parts
- Brake System
- Electrical
- Body & Frame
- Suspension
- Transmission
- Exhaust System

---

### 7. **StockTransaction** (Critical)

Records every stock movement (in/out)

**Suggested Fields:**

```dart
class StockTransaction {
  final String id;
  final String partId;        // → references BikePart.id
  final String userId;        // → references AppUser.id
  final TransactionType type; // IN, OUT, ADJUSTMENT
  final int quantity;         // +10 or -5
  final int stockBefore;      // Stock before transaction
  final int stockAfter;       // Stock after transaction
  final String? reason;       // "Purchase", "Sale", "Damage"
  final String? orderId;      // → references Order.id (if sale)
  final DateTime createdAt;
}

enum TransactionType {
  stockIn,      // Receiving from supplier
  stockOut,     // Sold to customer
  adjustment,   // Manual correction
  return,       // Customer return
  damage,       // Damaged/lost items
}
```

**Relationships:**

```
StockTransaction ─→ BikePart (many-to-one)
                 ─→ AppUser (many-to-one)
                 ─→ Order (many-to-one, optional)
```

**Usage:**

- Complete audit trail of stock changes
- Answer: "Who removed 5 units yesterday?"
- Track stock accuracy
- Generate inventory reports

---

### 8. **Order** (Sales)

Customer orders/sales

**Suggested Fields:**

```dart
class Order {
  final String id;
  final String orderNumber;   // "ORD-2025-001"
  final String userId;        // → references AppUser.id (who created)
  final String? customerName;
  final String? customerPhone;
  final OrderStatus status;   // pending, completed, cancelled
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? completedAt;
}

enum OrderStatus {
  pending,
  completed,
  cancelled,
  returned,
}
```

**Relationships:**

```
Order ─→ AppUser (many-to-one)
      └─→ OrderItem (one-to-many)

OrderItem ─→ Order (many-to-one)
          └─→ BikePart (many-to-one)
```

**OrderItem Fields:**

```dart
class OrderItem {
  final String id;
  final String orderId;       // → references Order.id
  final String partId;        // → references BikePart.id
  final String partName;      // Snapshot of part name
  final int quantity;
  final double unitPrice;     // Price at time of sale
  final double subtotal;      // quantity × unitPrice
}
```

---

## Complete Relationship Diagram

```
                    ┌──────────┐
                    │  Brand   │
                    └────┬─────┘
                         │ 1:N
                    ┌────▼──────┐
                    │ MotoModel │
                    └────┬──────┘
                         │ 1:N
    ┌─────────┐          │          ┌──────────┐
    │Supplier │          │          │ Category │
    └────┬────┘          │          └────┬─────┘
         │ 1:N           │               │ 1:N
         │          ┌────▼────┐          │
         └─────────→│BikePart │←─────────┘
                    └────┬────┘
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          │ 1:N          │ 1:N          │ 1:N
    ┌─────▼─────┐  ┌─────▼──────┐  ┌───▼────┐
    │OrderItem  │  │Stock       │  │Future: │
    │           │  │Transaction │  │Reviews │
    └─────┬─────┘  └─────┬──────┘  └────────┘
          │              │
    ┌─────▼─────┐  ┌─────▼──────┐
    │  Order    │  │  AppUser   │
    └───────────┘  └────────────┘
```

---

## Firestore Query Examples

### 1. Get all parts for a specific brand

```dart
FirebaseFirestore.instance
  .collection('bike_parts')
  .where('brandId', isEqualTo: 'yamaha_id')
  .get();
```

### 2. Get all parts for a specific model

```dart
FirebaseFirestore.instance
  .collection('bike_parts')
  .where('modelId', isEqualTo: 'yzfr15_id')
  .get();
```

### 3. Get low stock parts

```dart
FirebaseFirestore.instance
  .collection('bike_parts')
  .where('stock', isLessThanOrEqualTo: 'minThreshold')
  .get();
```

### 4. Get parts from a supplier

```dart
FirebaseFirestore.instance
  .collection('bike_parts')
  .where('supplierId', isEqualTo: 'supplier_id')
  .get();
```

### 5. Get stock transactions for a part

```dart
FirebaseFirestore.instance
  .collection('stock_transactions')
  .where('partId', isEqualTo: 'part_id')
  .orderBy('createdAt', descending: true)
  .limit(20)
  .get();
```

### 6. Get user's order history

```dart
FirebaseFirestore.instance
  .collection('orders')
  .where('userId', isEqualTo: 'user_id')
  .orderBy('createdAt', descending: true)
  .get();
```

---

## Data Integrity Rules

### Creating a New Part

```
1. Brand must exist (validate brandId)
2. Model must exist (validate modelId)
3. Supplier must exist (validate supplierId)
4. Category should exist (validate category)
5. Set initial stock = 0
6. Create initial StockTransaction if stock > 0
```

### Selling a Part (Creating Order)

```
1. Check if part.stock >= quantity
2. Create Order document
3. Create OrderItem subdocuments
4. For each OrderItem:
   a. Create StockTransaction (type: OUT)
   b. Update BikePart.stock -= quantity
5. Update Order.totalAmount
6. Set Order.status = completed
```

### Receiving Stock from Supplier

```
1. Create StockTransaction (type: IN)
2. Update BikePart.stock += quantity
3. Record transaction.userId (who received)
4. Optional: Link to PurchaseOrder
```

### Deleting a Part

```
⚠️ Never hard delete! Instead:
1. Set BikePart.isActive = false
2. Keep historical data for reports
3. Hide from active listings
```

---

## Security Considerations

### Firestore Security Rules Example

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read their own user document
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null &&
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Parts - read all, write only for staff/admin
    match /bike_parts/{partId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'staff'];
    }

    // Stock transactions - read all, create only, no updates
    match /stock_transactions/{transactionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null &&
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if false; // Never allow modifications
    }
  }
}
```

---

## Best Practices

### 1. **Always Use Transactions for Stock Changes**

```dart
await FirebaseFirestore.instance.runTransaction((transaction) async {
  // 1. Read current stock
  final partDoc = await transaction.get(partRef);
  final currentStock = partDoc.data()!['stock'];

  // 2. Calculate new stock
  final newStock = currentStock - quantitySold;

  // 3. Update part stock
  transaction.update(partRef, {'stock': newStock});

  // 4. Create stock transaction
  transaction.set(transactionRef, stockTransactionData);
});
```

### 2. **Denormalize for Performance**

Store commonly needed data directly in documents to avoid extra reads:

- Store `partName` in `OrderItem` (not just `partId`)
- Store `brandName` in `BikePart` (not just `brandId`)
- Store `userName` in `StockTransaction` (not just `userId`)

### 3. **Use Batch Writes for Multiple Updates**

```dart
final batch = FirebaseFirestore.instance.batch();
batch.update(partRef1, {'stock': newStock1});
batch.update(partRef2, {'stock': newStock2});
batch.set(transactionRef, transactionData);
await batch.commit();
```

### 4. **Index Critical Fields**

Create composite indexes in Firebase Console for:

- `bike_parts`: `(brandId, stock)`
- `bike_parts`: `(category, isActive)`
- `stock_transactions`: `(partId, createdAt)`
- `orders`: `(userId, createdAt)`

---

## Summary

This stock management system uses a **relational structure** implemented in Firestore's NoSQL database:

- **BikePart** is the central entity, connected to Brand, MotoModel, Supplier, and Category
- **StockTransaction** provides complete audit trail of inventory changes
- **Order/OrderItem** tracks sales and links to stock changes
- **AppUser** tracks who performs actions in the system

The key to maintaining data integrity is:

1. Always validate foreign key references before creating documents
2. Use Firestore transactions for stock changes
3. Never hard delete—use soft deletes (isActive flag)
4. Create StockTransaction records for every inventory change
5. Denormalize data where appropriate for performance

---

**Document Version:** 1.0  
**Last Updated:** October 2025  
**System:** Motorcycle Parts Stock Management
