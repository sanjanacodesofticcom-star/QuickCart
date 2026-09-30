/**
 * QuickCart Standalone Web Admin Dashboard
 * Real-time Product & Inventory Management
 */

class AdminApp {
  constructor() {
    this.currentView = 'dashboard';
    this.products = [];
    this.categories = [];
    this.orders = [];
    this.customers = [];
    this.stats = {};
    this.activeFilter = 'all';
    this.selectedCategory = 'all';
    this.searchQuery = '';
    this.sortOption = '';
    this.viewMode = 'table'; // 'table' or 'grid'

    this.init();
  }

  async init() {
    this.bindEvents();
    this.loadTheme();
    await this.refreshAllData();
  }

  bindEvents() {
    // Navigation
    document.querySelectorAll('.sidebar-nav .nav-item').forEach(item => {
      item.addEventListener('click', (e) => {
        const view = item.getAttribute('data-view');
        if (view) this.switchView(view);
      });
    });

    // Theme toggle
    document.getElementById('themeToggleBtn').addEventListener('click', () => {
      this.toggleTheme();
    });

    // Global Search
    const searchInput = document.getElementById('globalSearchInput');
    searchInput.addEventListener('input', (e) => {
      this.searchQuery = e.target.value;
      if (this.currentView !== 'products') {
        this.switchView('products');
      } else {
        this.renderProductsView();
      }
    });

    // Product Category Filter
    document.getElementById('productCategoryFilter').addEventListener('change', (e) => {
      this.selectedCategory = e.target.value;
      this.renderProductsView();
    });

    // Product Sort Filter
    document.getElementById('productSortSelect').addEventListener('change', (e) => {
      this.sortOption = e.target.value;
      this.renderProductsView();
    });

    // Product Filter Pills
    document.querySelectorAll('.filter-bar .tab-pill').forEach(pill => {
      pill.addEventListener('click', (e) => {
        document.querySelectorAll('.filter-bar .tab-pill').forEach(p => p.classList.remove('active'));
        pill.classList.add('active');
        this.activeFilter = pill.getAttribute('data-filter');
        this.renderProductsView();
      });
    });

    // Toggle Table / Grid view
    document.getElementById('toggleViewModeBtn').addEventListener('click', () => {
      this.viewMode = this.viewMode === 'table' ? 'grid' : 'table';
      const icon = document.querySelector('#toggleViewModeBtn i');
      if (this.viewMode === 'table') {
        icon.className = 'fa-solid fa-table-cells-large';
      } else {
        icon.className = 'fa-solid fa-table-list';
      }
      this.renderProductsView();
    });

    // Add Product button
    document.getElementById('openAddProductBtn').addEventListener('click', () => {
      this.openProductModal();
    });

    // Quick restock low button
    document.getElementById('quickRestockAllBtn').addEventListener('click', () => {
      this.bulkRestockLowStock();
    });
  }

  // -------------------------------------------------------------
  // DATA FETCHING & SYNC
  // -------------------------------------------------------------

  async refreshAllData() {
    try {
      await Promise.all([
        this.fetchStats(),
        this.fetchCategories(),
        this.fetchProducts(),
        this.fetchOrders(),
        this.fetchCustomers(),
        this.fetchSettings()
      ]);

      this.renderCurrentView();
    } catch (err) {
      console.error('Error refreshing data:', err);
      this.showToast('Failed to connect to local database server', 'error');
    }
  }

  async fetchStats() {
    const res = await fetch('/api/stats');
    this.stats = await res.json();
    this.updateStatsUI();
  }

  async fetchCategories() {
    const res = await fetch('/api/categories');
    this.categories = await res.json();
    this.updateCategoryDropdowns();
  }

  async fetchProducts() {
    const res = await fetch('/api/products');
    this.products = await res.json();
    document.getElementById('sidebarProductCount').textContent = this.products.length;
  }

  async fetchOrders() {
    const res = await fetch('/api/orders');
    this.orders = await res.json();
    document.getElementById('sidebarOrderCount').textContent = this.orders.length;
  }

  async fetchCustomers() {
    const res = await fetch('/api/users');
    this.customers = await res.json();
  }

  async fetchSettings() {
    const res = await fetch('/api/settings');
    const settings = await res.json();
    if (settings.storeName) document.getElementById('settingStoreName').value = settings.storeName;
    if (settings.deliveryMinutes) document.getElementById('settingDeliveryMins').value = settings.deliveryMinutes;
    if (settings.deliveryFee) document.getElementById('settingDeliveryFee').value = settings.deliveryFee;
    if (settings.freeDeliveryAbove) document.getElementById('settingFreeDeliveryThreshold').value = settings.freeDeliveryAbove;
    if (settings.isStoreOpen !== undefined) document.getElementById('settingStoreOpen').checked = settings.isStoreOpen;
  }

  // -------------------------------------------------------------
  // VIEW ROUTING
  // -------------------------------------------------------------

  switchView(viewId) {
    this.currentView = viewId;

    // Update sidebar active link
    document.querySelectorAll('.sidebar-nav .nav-item').forEach(item => {
      item.classList.toggle('active', item.getAttribute('data-view') === viewId);
    });

    // Hide all view sections
    document.querySelectorAll('.view-section').forEach(sec => {
      sec.style.display = 'none';
    });

    // Show target view
    const target = document.getElementById(`view-${viewId}`);
    if (target) target.style.display = 'block';

    // Update Header Titles
    const titles = {
      dashboard: { title: 'Dashboard Overview', sub: 'Real-time metrics, inventory health & quick actions' },
      products: { title: 'Products Catalog Management', sub: 'Add, update pricing, edit details & organize items' },
      inventory: { title: 'Warehouse Stock & Inventory Hub', sub: 'Real-time stock adjustments, thresholds & batch restocks' },
      categories: { title: 'Product Categories', sub: 'Department classifications & store structure' },
      orders: { title: 'Live Customer Orders', sub: 'Track dispatch progress & manage order fulfillments' },
      customers: { title: 'Customer Accounts', sub: 'Registered users, addresses & purchase history' },
      settings: { title: 'Store Operations Settings', sub: 'Delivery promises, minimum order values & parameters' }
    };

    if (titles[viewId]) {
      document.getElementById('viewTitle').textContent = titles[viewId].title;
      document.getElementById('viewSubtitle').textContent = titles[viewId].sub;
    }

    this.renderCurrentView();
  }

  renderCurrentView() {
    if (this.currentView === 'dashboard') this.renderDashboardView();
    else if (this.currentView === 'products') this.renderProductsView();
    else if (this.currentView === 'inventory') this.renderInventoryView();
    else if (this.currentView === 'categories') this.renderCategoriesView();
    else if (this.currentView === 'orders') this.renderOrdersView();
    else if (this.currentView === 'customers') this.renderCustomersView();
  }

  // -------------------------------------------------------------
  // STATS & DASHBOARD VIEW
  // -------------------------------------------------------------

  updateStatsUI() {
    if (!this.stats) return;

    document.getElementById('statTotalProducts').textContent = this.stats.totalProducts || 0;
    document.getElementById('statActiveProducts').textContent = `${this.stats.activeProducts || 0} Active`;
    document.getElementById('statLowStock').textContent = this.stats.lowStockCount || 0;
    document.getElementById('statOutOfStock').textContent = this.stats.outOfStockCount || 0;
    document.getElementById('statInventoryValue').textContent = `₹${(this.stats.totalInventoryValue || 0).toLocaleString('en-IN')}`;
    document.getElementById('statTotalRevenue').textContent = `₹${(this.stats.totalRevenue || 0).toLocaleString('en-IN')}`;
    document.getElementById('statOrderCount').textContent = `${this.stats.totalOrders || 0} Orders`;

    const badge = document.getElementById('sidebarLowStockBadge');
    if (this.stats.lowStockCount > 0 || this.stats.outOfStockCount > 0) {
      badge.textContent = (this.stats.lowStockCount + this.stats.outOfStockCount);
      badge.style.display = 'inline-block';
    } else {
      badge.style.display = 'none';
    }
  }

  renderDashboardView() {
    this.updateStatsUI();

    // Render Urgent Low Stock list in Dashboard
    const tbody = document.querySelector('#dashboardLowStockTable tbody');
    tbody.innerHTML = '';

    const lowStockItems = this.products.filter(p => p.stock <= (p.lowStockThreshold || 10));

    if (lowStockItems.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; color: var(--accent-green); padding: 30px;"><i class="fa-solid fa-circle-check" style="font-size: 24px; margin-bottom: 8px; display: block;"></i>All products have healthy stock levels!</td></tr>`;
    } else {
      lowStockItems.slice(0, 6).forEach(p => {
        const isOutOfStock = p.stock === 0;
        const statusBadge = isOutOfStock
          ? `<span class="badge-pill badge-out-stock"><i class="fa-solid fa-circle-xmark"></i> Out of Stock</span>`
          : `<span class="badge-pill badge-low-stock"><i class="fa-solid fa-triangle-exclamation"></i> Only ${p.stock} left</span>`;

        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td>
            <div class="prod-cell">
              <img src="${p.image}" class="prod-thumb" onerror="this.src='data:image/svg+xml,<svg xmlns=\\'http://www.w3.org/2000/svg\\' viewBox=\\'0 0 24 24\\' fill=\\'%23ccc\\'><rect width=\\'24\\' height=\\'24\\'/></svg>'">
              <div class="prod-info">
                <h4>${p.name}</h4>
                <span class="sku">${p.sku || p.id} • ${p.weight || ''}</span>
              </div>
            </div>
          </td>
          <td><span class="badge-pill badge-category">${p.categoryName}</span></td>
          <td><strong>₹${p.price}</strong></td>
          <td>${statusBadge}</td>
          <td>
            <button class="btn btn-primary btn-sm" onclick="app.adjustStock('${p.id}', 10)">
              <i class="fa-solid fa-plus"></i> Restock +10
            </button>
          </td>
        `;
        tbody.appendChild(tr);
      });
    }

    // Category Distribution
    const catList = document.getElementById('dashboardCategoryList');
    catList.innerHTML = '';

    const sortedCats = [...this.categories].sort((a, b) => (b.productCount || 0) - (a.productCount || 0));
    sortedCats.slice(0, 5).forEach(cat => {
      const percentage = this.products.length > 0 
        ? Math.round(((cat.productCount || 0) / this.products.length) * 100) 
        : 0;

      const div = document.createElement('div');
      div.innerHTML = `
        <div style="display: flex; justify-content: space-between; font-size: 13px; font-weight: 700; margin-bottom: 4px;">
          <span>${cat.name}</span>
          <span style="color: var(--text-muted);">${cat.productCount || 0} items (${percentage}%)</span>
        </div>
        <div style="height: 6px; background: var(--bg-main); border-radius: 4px; overflow: hidden;">
          <div style="width: ${percentage}%; height: 100%; background: var(--primary); border-radius: 4px;"></div>
        </div>
      `;
      catList.appendChild(div);
    });
  }

  // -------------------------------------------------------------
  // PRODUCTS CATALOG VIEW
  // -------------------------------------------------------------

  updateCategoryDropdowns() {
    const filterSelect = document.getElementById('productCategoryFilter');
    const formSelect = document.getElementById('prodCategoryId');

    if (filterSelect) {
      filterSelect.innerHTML = '<option value="all">All Categories</option>';
      this.categories.forEach(cat => {
        filterSelect.innerHTML += `<option value="${cat.id}">${cat.name}</option>`;
      });
      filterSelect.value = this.selectedCategory;
    }

    if (formSelect) {
      formSelect.innerHTML = '';
      this.categories.forEach(cat => {
        formSelect.innerHTML += `<option value="${cat.id}" data-name="${cat.name}">${cat.name}</option>`;
      });
    }
  }

  getFilteredProducts() {
    let list = [...this.products];

    // Filter by Category
    if (this.selectedCategory && this.selectedCategory !== 'all') {
      list = list.filter(p => p.categoryId === this.selectedCategory);
    }

    // Filter by Status Pill
    if (this.activeFilter === 'in_stock') {
      list = list.filter(p => p.stock > (p.lowStockThreshold || 10));
    } else if (this.activeFilter === 'low_stock') {
      list = list.filter(p => p.stock > 0 && p.stock <= (p.lowStockThreshold || 10));
    } else if (this.activeFilter === 'out_of_stock') {
      list = list.filter(p => p.stock === 0);
    } else if (this.activeFilter === 'inactive') {
      list = list.filter(p => !p.isActive);
    }

    // Search Query
    if (this.searchQuery) {
      const q = this.searchQuery.toLowerCase().trim();
      list = list.filter(p =>
        p.name.toLowerCase().includes(q) ||
        (p.sku && p.sku.toLowerCase().includes(q)) ||
        (p.categoryName && p.categoryName.toLowerCase().includes(q)) ||
        (p.tags && p.tags.some(t => t.toLowerCase().includes(q)))
      );
    }

    // Sorting
    if (this.sortOption === 'price_asc') list.sort((a, b) => a.price - b.price);
    else if (this.sortOption === 'price_desc') list.sort((a, b) => b.price - a.price);
    else if (this.sortOption === 'stock_asc') list.sort((a, b) => a.stock - b.stock);
    else if (this.sortOption === 'stock_desc') list.sort((a, b) => b.stock - a.stock);
    else if (this.sortOption === 'name_asc') list.sort((a, b) => a.name.localeCompare(b.name));

    return list;
  }

  renderProductsView() {
    const products = this.getFilteredProducts();
    const tableContainer = document.getElementById('productsTableContainer');
    const gridContainer = document.getElementById('productsGridContainer');

    if (this.viewMode === 'table') {
      tableContainer.style.display = 'block';
      gridContainer.style.display = 'none';
      this.renderProductsTable(products);
    } else {
      tableContainer.style.display = 'none';
      gridContainer.style.display = 'grid';
      this.renderProductsGrid(products);
    }
  }

  renderProductsTable(products) {
    const tbody = document.getElementById('productsTableBody');
    tbody.innerHTML = '';

    if (products.length === 0) {
      tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; padding: 40px; color: var(--text-muted);">No products match your filter criteria.</td></tr>`;
      return;
    }

    products.forEach(p => {
      const isOutOfStock = p.stock === 0;
      const isLowStock = p.stock > 0 && p.stock <= (p.lowStockThreshold || 10);
      
      const stockBadge = isOutOfStock
        ? `<span class="badge-pill badge-out-stock">Out of Stock (0)</span>`
        : isLowStock
        ? `<span class="badge-pill badge-low-stock">Low Stock (${p.stock})</span>`
        : `<span class="badge-pill badge-in-stock">In Stock (${p.stock})</span>`;

      const discountBadge = p.discountPercentage > 0
        ? `<span style="background: var(--accent-green-bg); color: var(--accent-green); font-size: 10px; font-weight: 800; padding: 2px 4px; border-radius: 4px;">${p.discountPercentage}% OFF</span>`
        : '';

      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>
          <div class="prod-cell">
            <img src="${p.image}" class="prod-thumb" onerror="this.src='data:image/svg+xml,<svg xmlns=\\'http://www.w3.org/2000/svg\\' viewBox=\\'0 0 24 24\\' fill=\\'%23ccc\\'><rect width=\\'24\\' height=\\'24\\'/></svg>'">
            <div class="prod-info">
              <h4>${p.name}</h4>
              <span class="sku">${p.sku || p.id}</span>
            </div>
          </div>
        </td>
        <td><span class="badge-pill badge-category">${p.categoryName}</span></td>
        <td>
          <div>
            <strong>₹${p.price}</strong>
            ${p.compareAtPrice > p.price ? `<span style="text-decoration: line-line-through; font-size: 11px; color: var(--text-muted); margin-left: 4px;">₹${p.compareAtPrice}</span>` : ''}
          </div>
          ${discountBadge}
        </td>
        <td><span style="font-size: 12px; font-weight: 600; color: var(--text-muted);">${p.weight || '1 pack'}</span></td>
        <td>
          <div class="stock-adjuster">
            <button class="stock-btn" onclick="app.adjustStock('${p.id}', -1)">-</button>
            <span class="stock-val">${p.stock}</span>
            <button class="stock-btn" onclick="app.adjustStock('${p.id}', 1)">+</button>
          </div>
          <div style="margin-top: 4px;">${stockBadge}</div>
        </td>
        <td>
          <button class="btn btn-sm ${p.isActive ? 'btn-outline' : 'btn-danger'}" style="padding: 3px 8px; font-size: 11px;" onclick="app.toggleProductActive('${p.id}')">
            ${p.isActive ? '🟢 Active' : '⚪ Inactive'}
          </button>
        </td>
        <td>
          <div style="display: flex; gap: 4px; flex-wrap: wrap;">
            ${p.isFeatured ? '<span class="badge-pill badge-featured">⭐ Featured</span>' : ''}
            ${p.isBestSeller ? '<span class="badge-pill" style="background: #FFF1F2; color: #E11D48;">🔥 Best</span>' : ''}
          </div>
        </td>
        <td style="text-align: right;">
          <div style="display: inline-flex; gap: 6px;">
            <button class="btn btn-icon btn-sm" title="Edit Product" onclick="app.editProduct('${p.id}')">
              <i class="fa-solid fa-pen-to-square"></i>
            </button>
            <button class="btn btn-icon btn-sm" title="Delete Product" style="color: var(--accent-red);" onclick="app.deleteProduct('${p.id}')">
              <i class="fa-solid fa-trash"></i>
            </button>
          </div>
        </td>
      `;
      tbody.appendChild(tr);
    });
  }

  renderProductsGrid(products) {
    const grid = document.getElementById('productsGridContainer');
    grid.innerHTML = '';

    products.forEach(p => {
      const card = document.createElement('div');
      card.className = 'product-item-card';
      card.innerHTML = `
        <div class="card-img-wrap">
          <img src="${p.image}" onerror="this.src='data:image/svg+xml,<svg xmlns=\\'http://www.w3.org/2000/svg\\' viewBox=\\'0 0 24 24\\' fill=\\'%23ccc\\'><rect width=\\'24\\' height=\\'24\\'/></svg>'">
          <span style="position: absolute; top: 8px; left: 8px;" class="badge-pill badge-category">${p.categoryName}</span>
        </div>
        <div>
          <h4 style="font-size: 14px; font-weight: 800; line-height: 1.3;">${p.name}</h4>
          <span style="font-size: 11px; color: var(--text-muted);">${p.weight} • SKU: ${p.sku}</span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <div>
            <strong style="font-size: 16px;">₹${p.price}</strong>
            ${p.compareAtPrice > p.price ? `<span style="font-size: 11px; color: var(--text-muted); text-decoration: line-through; margin-left: 4px;">₹${p.compareAtPrice}</span>` : ''}
          </div>
          <span class="badge-pill ${p.stock <= 10 ? 'badge-low-stock' : 'badge-in-stock'}">${p.stock} in stock</span>
        </div>
        <div style="display: flex; gap: 6px; margin-top: auto;">
          <button class="btn btn-outline btn-sm" style="flex: 1;" onclick="app.editProduct('${p.id}')">
            <i class="fa-solid fa-pen"></i> Edit
          </button>
          <button class="btn btn-primary btn-sm" onclick="app.adjustStock('${p.id}', 5)">
            +5 Stock
          </button>
        </div>
      `;
      grid.appendChild(card);
    });
  }

  // -------------------------------------------------------------
  // INVENTORY MANAGEMENT VIEW
  // -------------------------------------------------------------

  renderInventoryView() {
    const tbody = document.getElementById('inventoryTableBody');
    tbody.innerHTML = '';

    this.products.forEach(p => {
      const isOutOfStock = p.stock === 0;
      const isLowStock = p.stock > 0 && p.stock <= (p.lowStockThreshold || 10);
      const totalItemValue = (p.price * p.stock).toLocaleString('en-IN');

      let healthBadge = `<span class="badge-pill badge-in-stock"><i class="fa-solid fa-circle-check"></i> Healthy Stock</span>`;
      if (isOutOfStock) {
        healthBadge = `<span class="badge-pill badge-out-stock"><i class="fa-solid fa-circle-xmark"></i> Out of Stock</span>`;
      } else if (isLowStock) {
        healthBadge = `<span class="badge-pill badge-low-stock"><i class="fa-solid fa-triangle-exclamation"></i> Low Stock Warning</span>`;
      }

      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>
          <div class="prod-cell">
            <img src="${p.image}" class="prod-thumb" onerror="this.src='data:image/svg+xml,<svg xmlns=\\'http://www.w3.org/2000/svg\\' viewBox=\\'0 0 24 24\\' fill=\\'%23ccc\\'><rect width=\\'24\\' height=\\'24\\'/></svg>'">
            <div>
              <strong style="font-size: 13.5px;">${p.name}</strong>
              <div style="font-size: 11px; color: var(--text-muted);">SKU: ${p.sku} | ID: ${p.id}</div>
            </div>
          </div>
        </td>
        <td><span class="badge-pill badge-category">${p.categoryName}</span></td>
        <td><strong>₹${p.price}</strong> / unit</td>
        <td>${healthBadge}</td>
        <td>
          <div style="display: flex; align-items: center; gap: 6px;">
            <button class="btn btn-outline btn-sm" style="padding: 4px 8px;" onclick="app.adjustStock('${p.id}', -5)">-5</button>
            <button class="btn btn-outline btn-sm" style="padding: 4px 8px;" onclick="app.adjustStock('${p.id}', -1)">-1</button>
            <input type="number" value="${p.stock}" style="width: 55px; text-align: center; padding: 4px; border-radius: 6px; border: 1px solid var(--border-color); font-weight: 800;" onchange="app.setExactStock('${p.id}', this.value)">
            <button class="btn btn-primary btn-sm" style="padding: 4px 8px;" onclick="app.adjustStock('${p.id}', 1)">+1</button>
            <button class="btn btn-primary btn-sm" style="padding: 4px 8px;" onclick="app.adjustStock('${p.id}', 5)">+5</button>
            <button class="btn btn-dark btn-sm" style="padding: 4px 8px;" onclick="app.adjustStock('${p.id}', 20)">+20</button>
          </div>
        </td>
        <td><strong style="color: var(--accent-green);">₹${totalItemValue}</strong></td>
        <td>
          <span style="font-size: 11px; color: var(--text-muted);">Updated ${p.updatedAt || 'today'}</span>
        </td>
      `;
      tbody.appendChild(tr);
    });
  }

  // -------------------------------------------------------------
  // CATEGORIES VIEW
  // -------------------------------------------------------------

  renderCategoriesView() {
    const grid = document.getElementById('categoriesGrid');
    grid.innerHTML = '';

    this.categories.forEach(cat => {
      const card = document.createElement('div');
      card.className = 'panel-card';
      card.style.padding = '18px';
      card.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
          <div style="width: 44px; height: 44px; background: var(--primary-light); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 20px;">
            🏷️
          </div>
          <span class="badge-pill badge-in-stock">${cat.productCount || 0} Products</span>
        </div>
        <h4 style="font-size: 15px; font-weight: 800; margin-bottom: 4px;">${cat.name}</h4>
        <p style="font-size: 12px; color: var(--text-muted); margin-bottom: 12px; min-height: 36px;">${cat.description || 'QuickCart catalog department'}</p>
        <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--border-color); padding-top: 12px;">
          <span style="font-size: 11px; color: var(--text-muted);">ID: ${cat.id}</span>
          <button class="btn btn-outline btn-sm" onclick="app.filterByCategory('${cat.id}')">View Products</button>
        </div>
      `;
      grid.appendChild(card);
    });
  }

  filterByCategory(catId) {
    this.selectedCategory = catId;
    document.getElementById('productCategoryFilter').value = catId;
    this.switchView('products');
  }

  // -------------------------------------------------------------
  // ORDERS VIEW
  // -------------------------------------------------------------

  renderOrdersView() {
    const tbody = document.getElementById('ordersTableBody');
    tbody.innerHTML = '';

    if (this.orders.length === 0) {
      tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 40px; color: var(--text-muted);">No orders found.</td></tr>`;
      return;
    }

    this.orders.forEach(order => {
      const statusColors = {
        placed: 'background: #EFF6FF; color: #3B82F6;',
        processing: 'background: #FFFBEB; color: #F59E0B;',
        out_for_delivery: 'background: #FDF4FF; color: #C026D3;',
        delivered: 'background: #ECFDF5; color: #10B981;',
        cancelled: 'background: #FEF2F2; color: #EF4444;'
      };

      const itemsSummary = (order.items || [])
        .map(i => `${i.productName} (x${i.quantity})`)
        .join(', ');

      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td><strong>${order.id}</strong></td>
        <td>
          <div style="font-weight: 700;">${order.customerName || 'Customer'}</div>
          <div style="font-size: 11px; color: var(--text-muted);">${order.deliveryAddress?.fullAddress || ''}</div>
        </td>
        <td><span style="font-size: 12px; color: var(--text-muted);" title="${itemsSummary}">${order.items?.length || 0} items</span></td>
        <td><strong>₹${(order.total || 0).toLocaleString('en-IN')}</strong></td>
        <td><span style="font-size: 12px; color: var(--text-muted);">${order.createdAt || 'Recent'}</span></td>
        <td>
          <span class="badge-pill" style="${statusColors[order.status] || ''}">${(order.status || '').replace(/_/g, ' ').toUpperCase()}</span>
        </td>
        <td>
          <select class="filter-select" style="padding: 4px 8px; font-size: 12px;" onchange="app.updateOrderStatus('${order.id}', this.value)">
            <option value="placed" ${order.status === 'placed' ? 'selected' : ''}>Placed</option>
            <option value="processing" ${order.status === 'processing' ? 'selected' : ''}>Processing</option>
            <option value="out_for_delivery" ${order.status === 'out_for_delivery' ? 'selected' : ''}>Out for Delivery</option>
            <option value="delivered" ${order.status === 'delivered' ? 'selected' : ''}>Delivered</option>
            <option value="cancelled" ${order.status === 'cancelled' ? 'selected' : ''}>Cancelled</option>
          </select>
        </td>
      `;
      tbody.appendChild(tr);
    });
  }

  async updateOrderStatus(orderId, newStatus) {
    try {
      const res = await fetch(`/api/orders/${orderId}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus })
      });
      if (res.ok) {
        this.showToast(`Order ${orderId} updated to ${newStatus.replace(/_/g, ' ')}`);
        await this.fetchOrders();
      }
    } catch (err) {
      this.showToast('Failed to update order status', 'error');
    }
  }

  // -------------------------------------------------------------
  // CUSTOMERS VIEW
  // -------------------------------------------------------------

  renderCustomersView() {
    const tbody = document.getElementById('customersTableBody');
    tbody.innerHTML = '';

    this.customers.forEach(user => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>
          <div style="font-weight: 800;">${user.name}</div>
          <span style="font-size: 11px; color: var(--text-muted);">ID: ${user.id}</span>
        </td>
        <td>${user.email}</td>
        <td>+91 ${user.phone || ''}</td>
        <td><span class="badge-pill badge-category">${user.addresses?.length || 0} Addresses</span></td>
        <td><strong>${user.ordersCount || 0}</strong></td>
        <td><strong style="color: var(--accent-green);">₹${(user.totalSpent || 0).toLocaleString('en-IN')}</strong></td>
      `;
      tbody.appendChild(tr);
    });
  }

  // -------------------------------------------------------------
  // STOCK ADJUSTMENTS & ACTIONS
  // -------------------------------------------------------------

  async adjustStock(productId, delta) {
    try {
      const res = await fetch(`/api/products/${productId}/stock`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ delta })
      });
      const data = await res.json();
      if (res.ok) {
        this.showToast(`Stock adjusted: ${data.stock} units`);
        await this.refreshAllData();
      }
    } catch (err) {
      this.showToast('Failed to update stock', 'error');
    }
  }

  async setExactStock(productId, exactStock) {
    try {
      const stock = parseInt(exactStock, 10);
      const res = await fetch(`/api/products/${productId}/stock`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ stock })
      });
      const data = await res.json();
      if (res.ok) {
        this.showToast(`Stock set to ${data.stock} units`);
        await this.refreshAllData();
      }
    } catch (err) {
      this.showToast('Failed to update stock', 'error');
    }
  }

  async bulkRestockLowStock() {
    const lowStockItems = this.products.filter(p => p.stock <= (p.lowStockThreshold || 10));
    if (lowStockItems.length === 0) {
      this.showToast('All items are already well stocked!');
      return;
    }

    const adjustments = lowStockItems.map(p => ({ id: p.id, delta: 15 }));
    try {
      const res = await fetch('/api/inventory/bulk-adjust', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ adjustments })
      });
      if (res.ok) {
        this.showToast(`Restocked ${adjustments.length} low-stock products (+15 units each)`);
        await this.refreshAllData();
      }
    } catch (err) {
      this.showToast('Failed to bulk restock', 'error');
    }
  }

  async toggleProductActive(productId) {
    try {
      const res = await fetch(`/api/products/${productId}/toggle-active`, { method: 'PATCH' });
      const data = await res.json();
      if (res.ok) {
        this.showToast(data.message);
        await this.refreshAllData();
      }
    } catch (err) {
      this.showToast('Failed to toggle status', 'error');
    }
  }

  async deleteProduct(productId) {
    const prod = this.products.find(p => p.id === productId);
    if (!confirm(`Are you sure you want to permanently delete "${prod ? prod.name : productId}"?`)) {
      return;
    }

    try {
      const res = await fetch(`/api/products/${productId}`, { method: 'DELETE' });
      if (res.ok) {
        this.showToast('Product deleted from store catalog');
        await this.refreshAllData();
      }
    } catch (err) {
      this.showToast('Failed to delete product', 'error');
    }
  }

  // -------------------------------------------------------------
  // PRODUCT MODAL (ADD & EDIT)
  // -------------------------------------------------------------

  openProductModal(product = null) {
    this.updateCategoryDropdowns();
    const modal = document.getElementById('productModal');
    const title = document.getElementById('productModalTitle');
    const form = document.getElementById('productForm');

    form.reset();
    document.getElementById('imageUploadStatus').style.display = 'none';

    if (product) {
      title.textContent = `Edit Product: ${product.name}`;
      document.getElementById('prodEditId').value = product.id;
      document.getElementById('prodName').value = product.name;
      document.getElementById('prodSku').value = product.sku || '';
      document.getElementById('prodCategoryId').value = product.categoryId;
      document.getElementById('prodWeight').value = product.weight || '';
      document.getElementById('prodPrice').value = product.price;
      document.getElementById('prodCompareAtPrice').value = product.compareAtPrice || product.price;
      document.getElementById('prodStock').value = product.stock;
      document.getElementById('prodLowStockThreshold').value = product.lowStockThreshold || 10;
      document.getElementById('prodImage').value = product.image || '';
      document.getElementById('prodShortDesc').value = product.shortDescription || '';
      document.getElementById('prodTags').value = (product.tags || []).join(', ');
      document.getElementById('prodIsActive').checked = product.isActive !== false;
      document.getElementById('prodIsFeatured').checked = Boolean(product.isFeatured);
      document.getElementById('prodIsBestSeller').checked = Boolean(product.isBestSeller);
    } else {
      title.textContent = 'Add New Product';
      document.getElementById('prodEditId').value = '';
      document.getElementById('prodStock').value = '50';
      document.getElementById('prodLowStockThreshold').value = '10';
      document.getElementById('prodIsActive').checked = true;
    }

    modal.classList.add('active');
  }

  editProduct(productId) {
    const product = this.products.find(p => p.id === productId);
    if (product) this.openProductModal(product);
  }

  closeProductModal() {
    document.getElementById('productModal').classList.remove('active');
  }

  calculateDiscount() {
    const price = parseFloat(document.getElementById('prodPrice').value) || 0;
    const comparePrice = parseFloat(document.getElementById('prodCompareAtPrice').value) || 0;
    if (comparePrice > price) {
      const discount = Math.round(((comparePrice - price) / comparePrice) * 100);
      console.log(`Computed discount: ${discount}%`);
    }
  }

  async handleImageUpload(e) {
    const file = e.target.files[0];
    if (!file) return;

    const formData = new FormData();
    formData.append('image', file);

    try {
      const res = await fetch('/api/upload', {
        method: 'POST',
        body: formData
      });
      const data = await res.json();
      if (res.ok) {
        document.getElementById('prodImage').value = data.filePath;
        const status = document.getElementById('imageUploadStatus');
        status.textContent = `✓ Uploaded: ${file.name}`;
        status.style.display = 'block';
        this.showToast('Image uploaded successfully');
      }
    } catch (err) {
      this.showToast('Image upload failed', 'error');
    }
  }

  async handleProductFormSubmit(e) {
    e.preventDefault();
    const editId = document.getElementById('prodEditId').value;
    const categorySelect = document.getElementById('prodCategoryId');
    const selectedOption = categorySelect.options[categorySelect.selectedIndex];

    const payload = {
      name: document.getElementById('prodName').value.trim(),
      sku: document.getElementById('prodSku').value.trim(),
      categoryId: categorySelect.value,
      categoryName: selectedOption ? selectedOption.getAttribute('data-name') : '',
      weight: document.getElementById('prodWeight').value.trim(),
      price: parseFloat(document.getElementById('prodPrice').value),
      compareAtPrice: parseFloat(document.getElementById('prodCompareAtPrice').value) || parseFloat(document.getElementById('prodPrice').value),
      stock: parseInt(document.getElementById('prodStock').value, 10),
      lowStockThreshold: parseInt(document.getElementById('prodLowStockThreshold').value, 10),
      image: document.getElementById('prodImage').value.trim() || 'assets/images/products/placeholder.png',
      shortDescription: document.getElementById('prodShortDesc').value.trim(),
      tags: document.getElementById('prodTags').value.split(',').map(t => t.trim()).filter(Boolean),
      isActive: document.getElementById('prodIsActive').checked,
      isFeatured: document.getElementById('prodIsFeatured').checked,
      isBestSeller: document.getElementById('prodIsBestSeller').checked
    };

    const url = editId ? `/api/products/${editId}` : '/api/products';
    const method = editId ? 'PUT' : 'POST';

    try {
      const res = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (res.ok) {
        this.showToast(editId ? 'Product updated successfully' : 'New product added to store');
        this.closeProductModal();
        await this.refreshAllData();
      } else {
        this.showToast(data.error || 'Failed to save product', 'error');
      }
    } catch (err) {
      this.showToast('Network error while saving product', 'error');
    }
  }

  // -------------------------------------------------------------
  // CATEGORY MODAL
  // -------------------------------------------------------------

  openCategoryModal() {
    document.getElementById('categoryModal').classList.add('active');
  }

  closeCategoryModal() {
    document.getElementById('categoryModal').classList.remove('active');
  }

  async handleCategorySubmit(e) {
    e.preventDefault();
    const name = document.getElementById('catName').value.trim();
    const description = document.getElementById('catDesc').value.trim();
    const image = document.getElementById('catImage').value.trim();

    try {
      const res = await fetch('/api/categories', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, description, image })
      });
      if (res.ok) {
        this.showToast(`Category "${name}" added`);
        this.closeCategoryModal();
        await this.refreshAllData();
      }
    } catch (err) {
      this.showToast('Failed to add category', 'error');
    }
  }

  // -------------------------------------------------------------
  // SETTINGS
  // -------------------------------------------------------------

  async saveSettings() {
    const payload = {
      storeName: document.getElementById('settingStoreName').value,
      deliveryMinutes: parseInt(document.getElementById('settingDeliveryMins').value, 10),
      deliveryFee: parseFloat(document.getElementById('settingDeliveryFee').value),
      freeDeliveryAbove: parseFloat(document.getElementById('settingFreeDeliveryThreshold').value),
      isStoreOpen: document.getElementById('settingStoreOpen').checked
    };

    try {
      const res = await fetch('/api/settings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        this.showToast('Store settings saved successfully');
      }
    } catch (err) {
      this.showToast('Failed to save settings', 'error');
    }
  }

  // -------------------------------------------------------------
  // THEME & TOAST UTILITIES
  // -------------------------------------------------------------

  toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('admin_theme', newTheme);

    const icon = document.querySelector('#themeToggleBtn i');
    icon.className = newTheme === 'dark' ? 'fa-solid fa-sun' : 'fa-solid fa-moon';
  }

  loadTheme() {
    const savedTheme = localStorage.getItem('admin_theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
    const icon = document.querySelector('#themeToggleBtn i');
    icon.className = savedTheme === 'dark' ? 'fa-solid fa-sun' : 'fa-solid fa-moon';
  }

  showToast(message, type = 'success') {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.innerHTML = `
      <i class="fa-solid ${type === 'error' ? 'fa-circle-exclamation' : 'fa-circle-check'}" style="color: ${type === 'error' ? 'var(--accent-red)' : 'var(--primary)'}"></i>
      <span>${message}</span>
    `;

    container.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateX(100%)';
      toast.style.transition = 'all 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, 3200);
  }
}

// Instantiate global app
const app = new AdminApp();
window.app = app;
