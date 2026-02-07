const express = require('express');
const { body, validationResult } = require('express-validator');

const Category = require('../models/Category');
const { requireAdmin } = require('../middleware/requireAdmin');

const router = express.Router();

router.get('/', async (req, res) => {
  const categories = await Category.find({ isActive: true }).sort({ name: 1 });
  res.json(categories);
});

router.post(
  '/',
  requireAdmin,
  [body('name').trim().notEmpty().withMessage('Name is required')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation error', errors: errors.array() });
    }

    const category = await Category.create({ name: req.body.name, isActive: true });
    res.status(201).json(category);
  }
);

router.put('/:id', requireAdmin, async (req, res) => {
  const category = await Category.findByIdAndUpdate(
    req.params.id,
    { name: req.body.name, isActive: req.body.isActive },
    { new: true }
  );
  if (!category) {
    return res.status(404).json({ message: 'Category not found' });
  }
  res.json(category);
});

router.delete('/:id', requireAdmin, async (req, res) => {
  await Category.findByIdAndDelete(req.params.id);
  res.json({ ok: true });
});

module.exports = router;
