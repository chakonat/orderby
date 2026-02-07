const express = require('express');
const MenuItem = require('../models/MenuItem');
const Order = require('../models/Order');
const Restaurant = require('../models/Restaurant');
const Coupon = require('../models/Coupon');
const { requireAuth } = require('../middleware/requireAuth');

const router = express.Router();
const asyncHandler = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

router.post('/', requireAuth, asyncHandler(async (req, res) => {
  const { restaurantId, items, paymentMethod, customer, couponCode } = req.body;

  if (!restaurantId) {
    return res.status(400).json({ message: 'Restaurant is required' });
  }

  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ message: 'Items are required' });
  }

  if (!paymentMethod) {
    return res.status(400).json({ message: 'Payment method is required' });
  }

  if (!customer || !customer.name || !customer.phone || !customer.address) {
    return res.status(400).json({ message: 'Customer name, phone, and address are required' });
  }

  const restaurant = await Restaurant.findById(restaurantId);
  if (!restaurant) {
    return res.status(404).json({ message: 'Restaurant not found' });
  }

  const menuItems = await MenuItem.find({ _id: { $in: items.map((item) => item.menuItemId) } });

  if (menuItems.length === 0) {
    return res.status(400).json({ message: 'Menu items not found' });
  }

  const normalizedItems = items.map((item) => {
    const match = menuItems.find((menu) => String(menu._id) === String(item.menuItemId));
    if (!match) {
      return null;
    }

    return {
      menuItem: match._id,
      name: match.name,
      price: match.price,
      quantity: Math.max(1, Number(item.quantity || 1))
    };
  }).filter(Boolean);

  const subtotal = normalizedItems.reduce((sum, item) => sum + item.price * item.quantity, 0);

  if (subtotal < restaurant.minOrder) {
    return res.status(400).json({ message: `Minimum order is ${restaurant.minOrder}` });
  }

  let discount = 0;
  let appliedCouponCode = '';
  if (couponCode) {
    const coupon = await Coupon.findOne({ code: couponCode.toUpperCase(), isActive: true });
    if (!coupon) {
      return res.status(400).json({ message: 'Coupon not found or inactive' });
    }
    if (coupon.minOrder > 0 && subtotal < coupon.minOrder) {
      return res.status(400).json({ message: 'Order total is too low for coupon' });
    }

    if (coupon.discountPercent > 0) {
      discount = Math.round(subtotal * (coupon.discountPercent / 100));
    } else if (coupon.discountAmount > 0) {
      discount = coupon.discountAmount;
    }

    discount = Math.min(discount, subtotal);
    appliedCouponCode = coupon.code;
  }

  const deliveryFee = restaurant.deliveryFee || 0;
  const total = Math.max(subtotal - discount + deliveryFee, 0);

  const order = await Order.create({
    user: req.user.userId,
    restaurant: restaurant._id,
    items: normalizedItems,
    subtotal,
    deliveryFee,
    discount,
    total,
    couponCode: appliedCouponCode,
    paymentMethod,
    customer
  });

  res.status(201).json(order);
}));

router.get('/', requireAuth, asyncHandler(async (req, res) => {
  const orders = await Order.find({ user: req.user.userId })
    .sort({ createdAt: -1 })
    .limit(20)
    .populate('restaurant');
  res.json(orders);
}));

router.get('/:id', requireAuth, asyncHandler(async (req, res) => {
  const order = await Order.findOne({ _id: req.params.id, user: req.user.userId })
    .populate('items.menuItem')
    .populate('restaurant');
  if (!order) {
    return res.status(404).json({ message: 'Order not found' });
  }

  res.json(order);
}));

module.exports = router;
