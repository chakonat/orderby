const express = require('express');
const { body, validationResult } = require('express-validator');

const Promo = require('../models/Promo');
const { requireAdmin } = require('../middleware/requireAdmin');

const router = express.Router();

router.get('/', async (req, res) => {
  const promos = await Promo.find({ isActive: true }).sort({ createdAt: -1 });
  res.json(promos);
});

router.post(
  '/',
  requireAdmin,
  [body('title').trim().notEmpty().withMessage('Title is required')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation error', errors: errors.array() });
    }

    const promo = await Promo.create({
      title: req.body.title,
      subtitle: req.body.subtitle || '',
      badge: req.body.badge || '',
      imageUrl: req.body.imageUrl || '',
      discountPercent: Number(req.body.discountPercent || 0),
      isActive: req.body.isActive !== false,
    });

    res.status(201).json(promo);
  }
);

router.put('/:id', requireAdmin, async (req, res) => {
  const promo = await Promo.findByIdAndUpdate(
    req.params.id,
    {
      title: req.body.title,
      subtitle: req.body.subtitle || '',
      badge: req.body.badge || '',
      imageUrl: req.body.imageUrl || '',
      discountPercent: Number(req.body.discountPercent || 0),
      isActive: req.body.isActive !== false,
    },
    { new: true }
  );

  if (!promo) {
    return res.status(404).json({ message: 'Promo not found' });
  }

  res.json(promo);
});

router.delete('/:id', requireAdmin, async (req, res) => {
  await Promo.findByIdAndDelete(req.params.id);
  res.json({ ok: true });
});

module.exports = router;
