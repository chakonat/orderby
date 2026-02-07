const path = require('path');
const express = require('express');
const multer = require('multer');

const Restaurant = require('../models/Restaurant');
const MenuItem = require('../models/MenuItem');
const Promo = require('../models/Promo');
const Coupon = require('../models/Coupon');
const Category = require('../models/Category');
const Order = require('../models/Order');
const { cloudinary } = require('../config/cloudinary');
const { requireAdmin } = require('../middleware/requireAdmin');

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });

const adminUser = process.env.ADMIN_USER || 'admin';
const adminPassword = process.env.ADMIN_PASSWORD || 'admin123';

function ensureCloudinary() {
  if (!process.env.CLOUDINARY_CLOUD_NAME || !process.env.CLOUDINARY_API_KEY || !process.env.CLOUDINARY_API_SECRET) {
    throw new Error('Cloudinary не настроен в .env');
  }
}

router.get('/login', (req, res) => {
  res.render('login', { error: null });
});

router.post('/login', (req, res) => {
  const { username, password } = req.body;

  if (username === adminUser && password === adminPassword) {
    req.session.isAdmin = true;
    return res.redirect('/admin');
  }

  return res.status(401).render('login', { error: 'Неверный логин или пароль' });
});

router.get('/logout', (req, res) => {
  req.session.destroy(() => {
    res.redirect('/admin/login');
  });
});

router.get('/', requireAdmin, async (req, res) => {
  const restaurants = await Restaurant.find().sort({ createdAt: -1 });
  const menuItems = await MenuItem.find().sort({ createdAt: -1 }).limit(20).populate('restaurant');
  const promos = await Promo.find().sort({ createdAt: -1 }).limit(10);
  const coupons = await Coupon.find().sort({ createdAt: -1 }).limit(10);
  const categories = await Category.find().sort({ name: 1 });
  const orders = await Order.find().sort({ createdAt: -1 }).limit(10).populate('restaurant').populate('user');

  res.render('dashboard', { restaurants, menuItems, promos, coupons, categories, orders });
});

router.get('/restaurants/new', requireAdmin, (req, res) => {
  res.render('restaurant_form', { restaurant: null, error: null });
});

router.post('/restaurants', requireAdmin, upload.single('image'), async (req, res) => {
  try {
    const payload = req.body;
    let imageUrl = '';

    if (req.file) {
      ensureCloudinary();
      const result = await cloudinary.uploader.upload(
        `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`,
        { folder: 'orderby/restaurants' }
      );
      imageUrl = result.secure_url;
    }

    await Restaurant.create({
      name: payload.name,
      description: payload.description,
      cuisine: payload.cuisine,
      imageUrl,
      city: payload.city,
      rating: Number(payload.rating || 4.5),
      priceLevel: payload.priceLevel,
      deliveryTime: payload.deliveryTime,
      minOrder: Number(payload.minOrder || 0),
      deliveryFee: Number(payload.deliveryFee || 0),
      tags: (payload.tags || '').split(',').map((tag) => tag.trim()).filter(Boolean),
      isActive: payload.isActive === 'on',
    });

    res.redirect('/admin');
  } catch (error) {
    res.status(500).render('restaurant_form', { restaurant: null, error: error.message });
  }
});

router.get('/restaurants/:id/edit', requireAdmin, async (req, res) => {
  const restaurant = await Restaurant.findById(req.params.id);
  if (!restaurant) {
    return res.redirect('/admin');
  }

  res.render('restaurant_form', { restaurant, error: null });
});

router.post('/restaurants/:id', requireAdmin, upload.single('image'), async (req, res) => {
  try {
    const restaurant = await Restaurant.findById(req.params.id);
    if (!restaurant) {
      return res.redirect('/admin');
    }

    const payload = req.body;
    let imageUrl = restaurant.imageUrl;

    if (req.file) {
      ensureCloudinary();
      const result = await cloudinary.uploader.upload(
        `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`,
        { folder: 'orderby/restaurants' }
      );
      imageUrl = result.secure_url;
    }

    await Restaurant.findByIdAndUpdate(req.params.id, {
      name: payload.name,
      description: payload.description,
      cuisine: payload.cuisine,
      imageUrl,
      city: payload.city,
      rating: Number(payload.rating || 4.5),
      priceLevel: payload.priceLevel,
      deliveryTime: payload.deliveryTime,
      minOrder: Number(payload.minOrder || 0),
      deliveryFee: Number(payload.deliveryFee || 0),
      tags: (payload.tags || '').split(',').map((tag) => tag.trim()).filter(Boolean),
      isActive: payload.isActive === 'on',
    });

    res.redirect('/admin');
  } catch (error) {
    res.status(500).render('restaurant_form', { restaurant: null, error: error.message });
  }
});

router.post('/restaurants/:id/delete', requireAdmin, async (req, res) => {
  await Restaurant.findByIdAndDelete(req.params.id);
  await MenuItem.deleteMany({ restaurant: req.params.id });
  res.redirect('/admin');
});

router.get('/menu/new', requireAdmin, async (req, res) => {
  const restaurants = await Restaurant.find().sort({ name: 1 });
  res.render('menu_form', { item: null, restaurants, error: null });
});

router.post('/menu', requireAdmin, upload.single('image'), async (req, res) => {
  try {
    const payload = req.body;
    let imageUrl = '';

    if (req.file) {
      ensureCloudinary();
      const result = await cloudinary.uploader.upload(
        `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`,
        { folder: 'orderby/menu' }
      );
      imageUrl = result.secure_url;
    }

    await MenuItem.create({
      restaurant: payload.restaurant,
      name: payload.name,
      description: payload.description,
      category: payload.category,
      price: Number(payload.price || 0),
      calories: Number(payload.calories || 0),
      imageUrl,
      isPopular: payload.isPopular === 'on',
      isAvailable: payload.isAvailable === 'on',
    });

    res.redirect('/admin');
  } catch (error) {
    const restaurants = await Restaurant.find().sort({ name: 1 });
    res.status(500).render('menu_form', { item: null, restaurants, error: error.message });
  }
});

router.get('/menu/:id/edit', requireAdmin, async (req, res) => {
  const item = await MenuItem.findById(req.params.id);
  if (!item) {
    return res.redirect('/admin');
  }

  const restaurants = await Restaurant.find().sort({ name: 1 });
  res.render('menu_form', { item, restaurants, error: null });
});

router.post('/menu/:id', requireAdmin, upload.single('image'), async (req, res) => {
  try {
    const item = await MenuItem.findById(req.params.id);
    if (!item) {
      return res.redirect('/admin');
    }

    const payload = req.body;
    let imageUrl = item.imageUrl;

    if (req.file) {
      ensureCloudinary();
      const result = await cloudinary.uploader.upload(
        `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`,
        { folder: 'orderby/menu' }
      );
      imageUrl = result.secure_url;
    }

    await MenuItem.findByIdAndUpdate(req.params.id, {
      restaurant: payload.restaurant,
      name: payload.name,
      description: payload.description,
      category: payload.category,
      price: Number(payload.price || 0),
      calories: Number(payload.calories || 0),
      imageUrl,
      isPopular: payload.isPopular === 'on',
      isAvailable: payload.isAvailable === 'on',
    });

    res.redirect('/admin');
  } catch (error) {
    const restaurants = await Restaurant.find().sort({ name: 1 });
    res.status(500).render('menu_form', { item: null, restaurants, error: error.message });
  }
});

router.post('/menu/:id/delete', requireAdmin, async (req, res) => {
  await MenuItem.findByIdAndDelete(req.params.id);
  res.redirect('/admin');
});

router.get('/promos/new', requireAdmin, (req, res) => {
  res.render('promo_form', { promo: null, error: null });
});

router.post('/promos', requireAdmin, upload.single('image'), async (req, res) => {
  try {
    const payload = req.body;
    let imageUrl = '';

    if (req.file) {
      ensureCloudinary();
      const result = await cloudinary.uploader.upload(
        `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`,
        { folder: 'orderby/promos' }
      );
      imageUrl = result.secure_url;
    }

    await Promo.create({
      title: payload.title,
      subtitle: payload.subtitle,
      badge: payload.badge,
      imageUrl,
      discountPercent: Number(payload.discountPercent || 0),
      isActive: payload.isActive === 'on',
    });

    res.redirect('/admin');
  } catch (error) {
    res.status(500).render('promo_form', { promo: null, error: error.message });
  }
});

router.get('/promos/:id/edit', requireAdmin, async (req, res) => {
  const promo = await Promo.findById(req.params.id);
  if (!promo) {
    return res.redirect('/admin');
  }

  res.render('promo_form', { promo, error: null });
});

router.post('/promos/:id', requireAdmin, upload.single('image'), async (req, res) => {
  try {
    const promo = await Promo.findById(req.params.id);
    if (!promo) {
      return res.redirect('/admin');
    }

    const payload = req.body;
    let imageUrl = promo.imageUrl;

    if (req.file) {
      ensureCloudinary();
      const result = await cloudinary.uploader.upload(
        `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`,
        { folder: 'orderby/promos' }
      );
      imageUrl = result.secure_url;
    }

    await Promo.findByIdAndUpdate(req.params.id, {
      title: payload.title,
      subtitle: payload.subtitle,
      badge: payload.badge,
      imageUrl,
      discountPercent: Number(payload.discountPercent || 0),
      isActive: payload.isActive === 'on',
    });

    res.redirect('/admin');
  } catch (error) {
    res.status(500).render('promo_form', { promo: null, error: error.message });
  }
});

router.post('/promos/:id/delete', requireAdmin, async (req, res) => {
  await Promo.findByIdAndDelete(req.params.id);
  res.redirect('/admin');
});

router.get('/coupons/new', requireAdmin, (req, res) => {
  res.render('coupon_form', { coupon: null, error: null });
});

router.post('/coupons', requireAdmin, async (req, res) => {
  try {
    await Coupon.create({
      code: req.body.code.toUpperCase(),
      description: req.body.description,
      discountPercent: Number(req.body.discountPercent || 0),
      discountAmount: Number(req.body.discountAmount || 0),
      minOrder: Number(req.body.minOrder || 0),
      isActive: req.body.isActive === 'on',
    });
    res.redirect('/admin');
  } catch (error) {
    res.status(500).render('coupon_form', { coupon: null, error: error.message });
  }
});

router.get('/coupons/:id/edit', requireAdmin, async (req, res) => {
  const coupon = await Coupon.findById(req.params.id);
  if (!coupon) {
    return res.redirect('/admin');
  }

  res.render('coupon_form', { coupon, error: null });
});

router.post('/coupons/:id', requireAdmin, async (req, res) => {
  try {
    await Coupon.findByIdAndUpdate(req.params.id, {
      code: req.body.code.toUpperCase(),
      description: req.body.description,
      discountPercent: Number(req.body.discountPercent || 0),
      discountAmount: Number(req.body.discountAmount || 0),
      minOrder: Number(req.body.minOrder || 0),
      isActive: req.body.isActive === 'on',
    });
    res.redirect('/admin');
  } catch (error) {
    res.status(500).render('coupon_form', { coupon: null, error: error.message });
  }
});

router.post('/coupons/:id/delete', requireAdmin, async (req, res) => {
  await Coupon.findByIdAndDelete(req.params.id);
  res.redirect('/admin');
});

router.get('/categories/new', requireAdmin, (req, res) => {
  res.render('category_form', { category: null, error: null });
});

router.post('/categories', requireAdmin, async (req, res) => {
  try {
    await Category.create({ name: req.body.name, isActive: req.body.isActive === 'on' });
    res.redirect('/admin');
  } catch (error) {
    res.status(500).render('category_form', { category: null, error: error.message });
  }
});

router.get('/categories/:id/edit', requireAdmin, async (req, res) => {
  const category = await Category.findById(req.params.id);
  if (!category) {
    return res.redirect('/admin');
  }

  res.render('category_form', { category, error: null });
});

router.post('/categories/:id', requireAdmin, async (req, res) => {
  try {
    await Category.findByIdAndUpdate(req.params.id, {
      name: req.body.name,
      isActive: req.body.isActive === 'on',
    });
    res.redirect('/admin');
  } catch (error) {
    res.status(500).render('category_form', { category: null, error: error.message });
  }
});

router.post('/categories/:id/delete', requireAdmin, async (req, res) => {
  await Category.findByIdAndDelete(req.params.id);
  res.redirect('/admin');
});

router.post('/orders/:id/status', requireAdmin, async (req, res) => {
  await Order.findByIdAndUpdate(req.params.id, { status: req.body.status });
  res.redirect('/admin');
});

module.exports = router;
