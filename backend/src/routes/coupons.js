const express = require('express');
const { body, validationResult } = require('express-validator');

const Coupon = require('../models/Coupon');
const { requireAdmin } = require('../middleware/requireAdmin');

const router = express.Router();

router.get('/', requireAdmin, async (req, res) => {
  const coupons = await Coupon.find().sort({ createdAt: -1 });
  res.json(coupons);
});

router.post(
  '/',
  requireAdmin,
  [
    body('code').trim().notEmpty().withMessage('Code is required'),
    body('discountPercent').optional().isFloat({ min: 0, max: 100 }),
    body('discountAmount').optional().isFloat({ min: 0 }),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation error', errors: errors.array() });
    }

    const coupon = await Coupon.create({
      code: req.body.code.toUpperCase(),
      description: req.body.description || '',
      discountPercent: Number(req.body.discountPercent || 0),
      discountAmount: Number(req.body.discountAmount || 0),
      minOrder: Number(req.body.minOrder || 0),
      isActive: req.body.isActive !== false,
    });

    res.status(201).json(coupon);
  }
);

router.put('/:id', requireAdmin, async (req, res) => {
  const coupon = await Coupon.findByIdAndUpdate(
    req.params.id,
    {
      code: req.body.code?.toUpperCase() ?? req.body.code,
      description: req.body.description || '',
      discountPercent: Number(req.body.discountPercent || 0),
      discountAmount: Number(req.body.discountAmount || 0),
      minOrder: Number(req.body.minOrder || 0),
      isActive: req.body.isActive !== false,
    },
    { new: true }
  );

  if (!coupon) {
    return res.status(404).json({ message: 'Coupon not found' });
  }

  res.json(coupon);
});

router.delete('/:id', requireAdmin, async (req, res) => {
  await Coupon.findByIdAndDelete(req.params.id);
  res.json({ ok: true });
});

module.exports = router;
