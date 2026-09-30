const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const multer = require('multer');

const app = express();
const PORT = process.env.PORT || 3000;

// Paths to workspace data
const DATA_DIR = path.join(__dirname, '..', 'assets', 'data');
const IMAGES_DIR = path.join(__dirname, '..', 'assets', 'images');
const PRODUCTS_JSON_PATH = path.join(DATA_DIR, 'products.json');
const CATEGORIES_JSON_PATH = path.join(DATA_DIR, 'categories.json');
const ORDERS_JSON_PATH = path.join(DATA_DIR, 'orders.json');
const USERS_JSON_PATH = path.join(DATA_DIR, 'users.json');
const SETTINGS_JSON_PATH = path.join(DATA_DIR, 'settings.json');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static assets from the Flutter project
app.use('/assets', express.static(path.join(__dirname, '..', 'assets')));
// Serve Flutter Web Customer App
const FLUTTER_WEB_DIR = path.join(__dirname, '..', 'build', 'web');
if (fs.existsSync(FLUTTER_WEB_DIR)) {
  app.use('/app', express.static(FLUTTER_WEB_DIR));
}
// Serve admin web UI
app.use(express.static(path.join(__dirname, 'public')));


// Configure Multer for product image uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = path.join(IMAGES_DIR, 'products');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname) || '.png';
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, 'prod-' + uniqueSuffix + ext);
  }
});
const upload = multer({ storage: storage });

// Helper functions for reading/writing JSON
function readJson(filePath, defaultValue = []) {
  try {
    if (!fs.existsSync(filePath)) {
      return defaultValue;
    }
    const data = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(data);
  } catch (err) {
    console.error(`Error reading ${filePath}:`, err);
    return defaultValue;
  }
}

function writeJson(filePath, data) {
  try {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf-8');
    return true;
  } catch (err) {
    console.error(`Error writing ${filePath}:`, err);
    return false;
  }
}

// -------------------------------------------------------------
// API ENDPOINTS
// -------------------------------------------------------------

// 1. Dashboard Statistics
app.get('/api/stats', (req, res) => {
  const products = readJson(PRODUCTS_JSON_PATH, []);
  const categories = readJson(CATEGORIES_JSON_PATH, []);
  const orders = readJson(ORDERS_JSON_PATH, []);
  const users = readJson(USERS_JSON_PATH, []);

  const totalProducts = products.length;
  const activeProducts = products.filter(p => p.isActive).length;
  const lowStockCount = products.filter(p => p.stock > 0 && p.stock <= (p.lowStockThreshold || 10)).length;
  const outOfStockCount = products.filter(p => p.stock === 0).length;
  const inStockCount = products.filter(p => p.stock > (p.lowStockThreshold || 10)).length;
  
  const totalInventoryValue = products.reduce((acc, p) => acc + (p.price * (p.stock || 0)), 0);
  const totalOrders = orders.length;
  const totalRevenue = orders.reduce((acc, o) => acc + (o.total || 0), 0);

  const categoryStockBreakdown = categories.map(cat => {
    const catProducts = products.filter(p => p.categoryId === cat.id);
    const catTotalStock = catProducts.reduce((acc, p) => acc + (p.stock || 0), 0);
    const catTotalValue = catProducts.reduce((acc, p) => acc + (p.price * (p.stock || 0)), 0);
    return {
      categoryId: cat.id,
      categoryName: cat.name,
      productCount: catProducts.length,
      totalStock: catTotalStock,
      totalValue: catTotalValue,
    };
  });

  const lowStockProducts = products
    .filter(p => p.stock <= (p.lowStockThreshold || 10))
    .sort((a, b) => a.stock - b.stock)
    .slice(0, 10);

  res.json({
    totalProducts,
    activeProducts,
    inStockCount,
    lowStockCount,
    outOfStockCount,
    totalInventoryValue,
    totalCategories: categories.length,
    totalOrders,
    totalRevenue,
    totalCustomers: users.length,
    categoryStockBreakdown,
    lowStockProducts,
    recentOrders: orders.slice(0, 5)
  });
});

// 2. Products API
app.get('/api/products', (req, res) => {
  let products = readJson(PRODUCTS_JSON_PATH, []);
  const { category, search, status, sort } = req.query;

  if (category && category !== 'all') {
    products = products.filter(p => p.categoryId === category);
  }

  if (status) {
    if (status === 'low_stock') {
      products = products.filter(p => p.stock > 0 && p.stock <= (p.lowStockThreshold || 10));
    } else if (status === 'out_of_stock') {
      products = products.filter(p => p.stock === 0);
    } else if (status === 'in_stock') {
      products = products.filter(p => p.stock > (p.lowStockThreshold || 10));
    } else if (status === 'active') {
      products = products.filter(p => p.isActive);
    } else if (status === 'inactive') {
      products = products.filter(p => !p.isActive);
    }
  }

  if (search) {
    const q = search.toLowerCase().trim();
    products = products.filter(p => 
      p.name.toLowerCase().includes(q) ||
      (p.sku && p.sku.toLowerCase().includes(q)) ||
      (p.categoryName && p.categoryName.toLowerCase().includes(q)) ||
      (p.shortDescription && p.shortDescription.toLowerCase().includes(q)) ||
      (p.tags && p.tags.some(t => t.toLowerCase().includes(q)))
    );
  }

  if (sort) {
    if (sort === 'price_asc') products.sort((a, b) => a.price - b.price);
    else if (sort === 'price_desc') products.sort((a, b) => b.price - a.price);
    else if (sort === 'stock_asc') products.sort((a, b) => a.stock - b.stock);
    else if (sort === 'stock_desc') products.sort((a, b) => b.stock - a.stock);
    else if (sort === 'name_asc') products.sort((a, b) => a.name.localeCompare(b.name));
    else if (sort === 'name_desc') products.sort((a, b) => b.name.localeCompare(a.name));
  }

  res.json(products);
});

app.get('/api/products/:id', (req, res) => {
  const products = readJson(PRODUCTS_JSON_PATH, []);
  const product = products.find(p => p.id === req.params.id);
  if (!product) return res.status(404).json({ error: 'Product not found' });
  res.json(product);
});

// Create Product
app.post('/api/products', (req, res) => {
  const products = readJson(PRODUCTS_JSON_PATH, []);
  const categories = readJson(CATEGORIES_JSON_PATH, []);

  const body = req.body;
  if (!body.name || !body.price) {
    return res.status(400).json({ error: 'Product name and price are required' });
  }

  // Generate unique ID like P026
  let nextNum = 1;
  products.forEach(p => {
    const match = p.id.match(/^P(\d+)$/);
    if (match) {
      const num = parseInt(match[1], 10);
      if (num >= nextNum) nextNum = num + 1;
    }
  });
  const id = `P${String(nextNum).padStart(3, '0')}`;

  const category = categories.find(c => c.id === body.categoryId) || {
    id: body.categoryId || 'CAT001',
    name: body.categoryName || 'General'
  };

  const price = Number(body.price) || 0;
  const compareAtPrice = Number(body.compareAtPrice) || price;
  const discountPercentage = compareAtPrice > price 
    ? Math.round(((compareAtPrice - price) / compareAtPrice) * 100) 
    : (Number(body.discountPercentage) || 0);

  const newProduct = {
    id,
    sku: body.sku || `SKU-${id}`,
    name: body.name.trim(),
    slug: body.slug || body.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, ''),
    categoryId: category.id,
    categoryName: category.name,
    description: body.description || body.name,
    shortDescription: body.shortDescription || body.name,
    price: price,
    compareAtPrice: compareAtPrice,
    discountPercentage: discountPercentage,
    currency: body.currency || 'INR',
    unit: body.unit || 'pack',
    weight: body.weight || '1 pack',
    stock: parseInt(body.stock, 10) || 0,
    lowStockThreshold: parseInt(body.lowStockThreshold, 10) || 10,
    image: body.image || 'assets/images/products/placeholder.png',
    images: body.images || [body.image || 'assets/images/products/placeholder.png'],
    isActive: body.isActive !== undefined ? Boolean(body.isActive) : true,
    isFeatured: Boolean(body.isFeatured),
    isBestSeller: Boolean(body.isBestSeller),
    rating: Number(body.rating) || 4.5,
    reviewCount: parseInt(body.reviewCount, 10) || 12,
    tags: Array.isArray(body.tags) ? body.tags : (body.tags ? body.tags.split(',').map(t => t.trim()) : []),
    createdAt: new Date().toISOString().split('T')[0],
    updatedAt: new Date().toISOString().split('T')[0]
  };

  products.unshift(newProduct);
  writeJson(PRODUCTS_JSON_PATH, products);

  res.status(201).json({
    message: 'Product created successfully',
    product: newProduct
  });
});

// Update Product
app.put('/api/products/:id', (req, res) => {
  const products = readJson(PRODUCTS_JSON_PATH, []);
  const index = products.findIndex(p => p.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Product not found' });
  }

  const existing = products[index];
  const body = req.body;

  const price = body.price !== undefined ? Number(body.price) : existing.price;
  const compareAtPrice = body.compareAtPrice !== undefined ? Number(body.compareAtPrice) : existing.compareAtPrice;
  const discountPercentage = compareAtPrice > price 
    ? Math.round(((compareAtPrice - price) / compareAtPrice) * 100) 
    : (body.discountPercentage !== undefined ? Number(body.discountPercentage) : existing.discountPercentage);

  const updatedProduct = {
    ...existing,
    name: body.name !== undefined ? body.name.trim() : existing.name,
    sku: body.sku !== undefined ? body.sku.trim() : existing.sku,
    slug: body.slug !== undefined ? body.slug : existing.slug,
    categoryId: body.categoryId !== undefined ? body.categoryId : existing.categoryId,
    categoryName: body.categoryName !== undefined ? body.categoryName : existing.categoryName,
    description: body.description !== undefined ? body.description : existing.description,
    shortDescription: body.shortDescription !== undefined ? body.shortDescription : existing.shortDescription,
    price: price,
    compareAtPrice: compareAtPrice,
    discountPercentage: discountPercentage,
    unit: body.unit !== undefined ? body.unit : existing.unit,
    weight: body.weight !== undefined ? body.weight : existing.weight,
    stock: body.stock !== undefined ? parseInt(body.stock, 10) : existing.stock,
    lowStockThreshold: body.lowStockThreshold !== undefined ? parseInt(body.lowStockThreshold, 10) : existing.lowStockThreshold,
    image: body.image !== undefined ? body.image : existing.image,
    images: body.images !== undefined ? body.images : existing.images,
    isActive: body.isActive !== undefined ? Boolean(body.isActive) : existing.isActive,
    isFeatured: body.isFeatured !== undefined ? Boolean(body.isFeatured) : existing.isFeatured,
    isBestSeller: body.isBestSeller !== undefined ? Boolean(body.isBestSeller) : existing.isBestSeller,
    tags: body.tags !== undefined 
      ? (Array.isArray(body.tags) ? body.tags : body.tags.split(',').map(t => t.trim()))
      : existing.tags,
    updatedAt: new Date().toISOString().split('T')[0]
  };

  products[index] = updatedProduct;
  writeJson(PRODUCTS_JSON_PATH, products);

  res.json({
    message: 'Product updated successfully',
    product: updatedProduct
  });
});

// Quick Stock Adjust API
app.patch('/api/products/:id/stock', (req, res) => {
  const products = readJson(PRODUCTS_JSON_PATH, []);
  const index = products.findIndex(p => p.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Product not found' });
  }

  const { stock, delta } = req.body;
  let newStock = products[index].stock;

  if (stock !== undefined) {
    newStock = Math.max(0, parseInt(stock, 10));
  } else if (delta !== undefined) {
    newStock = Math.max(0, newStock + parseInt(delta, 10));
  }

  products[index].stock = newStock;
  products[index].updatedAt = new Date().toISOString().split('T')[0];

  writeJson(PRODUCTS_JSON_PATH, products);

  res.json({
    message: 'Stock updated',
    id: products[index].id,
    stock: newStock
  });
});

// Toggle Active status
app.patch('/api/products/:id/toggle-active', (req, res) => {
  const products = readJson(PRODUCTS_JSON_PATH, []);
  const index = products.findIndex(p => p.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Product not found' });
  }

  products[index].isActive = !products[index].isActive;
  products[index].updatedAt = new Date().toISOString().split('T')[0];
  writeJson(PRODUCTS_JSON_PATH, products);

  res.json({
    message: `Product is now ${products[index].isActive ? 'Active' : 'Inactive'}`,
    id: products[index].id,
    isActive: products[index].isActive
  });
});

// Delete Product
app.delete('/api/products/:id', (req, res) => {
  let products = readJson(PRODUCTS_JSON_PATH, []);
  const initialLen = products.length;
  products = products.filter(p => p.id !== req.params.id);
  if (products.length === initialLen) {
    return res.status(404).json({ error: 'Product not found' });
  }

  writeJson(PRODUCTS_JSON_PATH, products);
  res.json({ message: 'Product deleted successfully', id: req.params.id });
});

// 3. Inventory Bulk Update API
app.post('/api/inventory/bulk-adjust', (req, res) => {
  const { adjustments } = req.body; // Array of { id, stock or delta }
  if (!Array.isArray(adjustments)) {
    return res.status(400).json({ error: 'Adjustments must be an array' });
  }

  const products = readJson(PRODUCTS_JSON_PATH, []);
  let updatedCount = 0;

  adjustments.forEach(adj => {
    const prod = products.find(p => p.id === adj.id);
    if (prod) {
      if (adj.stock !== undefined) {
        prod.stock = Math.max(0, parseInt(adj.stock, 10));
      } else if (adj.delta !== undefined) {
        prod.stock = Math.max(0, prod.stock + parseInt(adj.delta, 10));
      }
      prod.updatedAt = new Date().toISOString().split('T')[0];
      updatedCount++;
    }
  });

  writeJson(PRODUCTS_JSON_PATH, products);
  res.json({ message: `Updated stock for ${updatedCount} products` });
});

// 4. Categories API
app.get('/api/categories', (req, res) => {
  const categories = readJson(CATEGORIES_JSON_PATH, []);
  const products = readJson(PRODUCTS_JSON_PATH, []);

  const enrichedCategories = categories.map(cat => {
    const count = products.filter(p => p.categoryId === cat.id).length;
    return { ...cat, productCount: count };
  });

  res.json(enrichedCategories);
});

app.post('/api/categories', (req, res) => {
  const categories = readJson(CATEGORIES_JSON_PATH, []);
  const body = req.body;
  if (!body.name) return res.status(400).json({ error: 'Category name is required' });

  let nextNum = 1;
  categories.forEach(c => {
    const match = c.id.match(/^CAT(\d+)$/);
    if (match) {
      const num = parseInt(match[1], 10);
      if (num >= nextNum) nextNum = num + 1;
    }
  });
  const id = `CAT${String(nextNum).padStart(3, '0')}`;

  const newCat = {
    id,
    name: body.name.trim(),
    slug: body.slug || body.name.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
    description: body.description || '',
    image: body.image || 'assets/images/categories/general.png',
    isActive: body.isActive !== undefined ? Boolean(body.isActive) : true,
    sortOrder: categories.length + 1
  };

  categories.push(newCat);
  writeJson(CATEGORIES_JSON_PATH, categories);
  res.status(201).json({ message: 'Category added', category: newCat });
});

app.put('/api/categories/:id', (req, res) => {
  const categories = readJson(CATEGORIES_JSON_PATH, []);
  const index = categories.findIndex(c => c.id === req.params.id);
  if (index === -1) return res.status(404).json({ error: 'Category not found' });

  categories[index] = {
    ...categories[index],
    name: req.body.name || categories[index].name,
    description: req.body.description !== undefined ? req.body.description : categories[index].description,
    image: req.body.image || categories[index].image,
    isActive: req.body.isActive !== undefined ? Boolean(req.body.isActive) : categories[index].isActive,
  };

  writeJson(CATEGORIES_JSON_PATH, categories);
  res.json({ message: 'Category updated', category: categories[index] });
});

app.delete('/api/categories/:id', (req, res) => {
  let categories = readJson(CATEGORIES_JSON_PATH, []);
  categories = categories.filter(c => c.id !== req.params.id);
  writeJson(CATEGORIES_JSON_PATH, categories);
  res.json({ message: 'Category deleted' });
});

// 5. Orders API
app.get('/api/orders', (req, res) => {
  const orders = readJson(ORDERS_JSON_PATH, []);
  res.json(orders);
});

app.patch('/api/orders/:id/status', (req, res) => {
  const orders = readJson(ORDERS_JSON_PATH, []);
  const order = orders.find(o => o.id === req.params.id);
  if (!order) return res.status(404).json({ error: 'Order not found' });

  order.status = req.body.status || order.status;
  writeJson(ORDERS_JSON_PATH, orders);
  res.json({ message: 'Order status updated', order });
});

// 6. Customers API
app.get('/api/users', (req, res) => {
  const users = readJson(USERS_JSON_PATH, []);
  const orders = readJson(ORDERS_JSON_PATH, []);

  const enrichedUsers = users.map(u => {
    const userOrders = orders.filter(o => o.userId === u.id);
    const spent = userOrders.reduce((acc, o) => acc + (o.total || 0), 0);
    return {
      ...u,
      ordersCount: userOrders.length,
      totalSpent: spent
    };
  });

  res.json(enrichedUsers);
});

// 7. Settings API
app.get('/api/settings', (req, res) => {
  const settings = readJson(SETTINGS_JSON_PATH, {});
  res.json(settings);
});

app.post('/api/settings', (req, res) => {
  writeJson(SETTINGS_JSON_PATH, req.body);
  res.json({ message: 'Settings saved', settings: req.body });
});

// 8. Image Upload Endpoint
app.post('/api/upload', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No image file uploaded' });
  }
  const relativePath = `assets/images/products/${req.file.filename}`;
  res.json({
    message: 'Image uploaded successfully',
    filePath: relativePath,
    url: `http://localhost:${PORT}/${relativePath}`
  });
});

if (process.env.NODE_ENV !== 'production' || !process.env.VERCEL) {
  app.listen(PORT, () => {
    console.log(`====================================================`);
    console.log(`🚀 QuickCart Web Admin Server is running on:`);
    console.log(`   👉 Localhost: http://localhost:${PORT}`);
    console.log(`   👉 Dashboard: http://localhost:${PORT}/index.html`);
    console.log(`====================================================`);
  });
}

module.exports = app;

