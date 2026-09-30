# QuickCart — 10-Minute Quick Commerce Store & Admin Suite

QuickCart is a high-performance 10-minute grocery and essentials delivery application built with Flutter, complemented by a dedicated **Standalone Web Admin Panel** running on localhost for store and inventory management.

---

## ⚡ Standalone Web Admin Dashboard (Localhost)

A standalone web application to add/edit products, manage warehouse stock, track orders, and configure store settings.

### 🌐 Accessing the Dashboard:
- **URL:** [http://localhost:3000](http://localhost:3000)

### 🚀 Starting the Admin Server:
```bash
cd admin_panel
npm install
npm start
```

### ✨ Features:
- 📊 **Dashboard Overview:** Real-time stock valuation, order stats, low-stock warnings, and revenue metrics.
- 📦 **Products Catalog:** Add new products with auto-discount computation, image upload, tags, and category assignment.
- 🏬 **Inventory Management:** Instant stock adjustments (`-5`, `-1`, `+1`, `+5`, `+20`), batch restock, and low stock threshold alerts.
- 🏷️ **Categories Hub:** Manage departments, assign icons, and view product distributions.
- 🧾 **Live Orders:** Track customer orders and update dispatch stages in real-time.
- 👥 **Customer Directory:** View customer accounts, saved addresses, and total spent.
- 💾 **Instant JSON Persistence:** All changes directly sync with `assets/data/*.json`.

---

## 📱 Mobile App (Flutter)

### 🚀 Running on Android Emulator:
```bash
flutter emulators --launch medium_phone
flutter run
```

