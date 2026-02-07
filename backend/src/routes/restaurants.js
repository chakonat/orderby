const express = require('express');
const Restaurant = require('../models/Restaurant');
const MenuItem = require('../models/MenuItem');

const router = express.Router();
const asyncHandler = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

router.get('/', asyncHandler(async (req, res) => {
  const { q } = req.query;
  const filter = { isActive: true };

  if (q) {
    filter.name = { $regex: q, $options: 'i' };
  }

  const restaurants = await Restaurant.find(filter).sort({ rating: -1, createdAt: -1 });
  res.json(restaurants);
}));

router.get('/:id', asyncHandler(async (req, res) => {
  const restaurant = await Restaurant.findById(req.params.id);
  if (!restaurant) {
    return res.status(404).json({ message: 'Restaurant not found' });
  }

  res.json(restaurant);
}));

router.get('/:id/menu', asyncHandler(async (req, res) => {
  const menu = await MenuItem.find({ restaurant: req.params.id, isAvailable: true }).sort({ isPopular: -1, createdAt: -1 });
  res.json(menu);
}));

module.exports = router;
