const express = require('express');
const { body, validationResult } = require('express-validator');

const User = require('../models/User');
const { requireAuth } = require('../middleware/requireAuth');

const router = express.Router();

router.get('/me', requireAuth, async (req, res) => {
  const user = await User.findById(req.user.userId).lean();
  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }

  res.json({
    id: user._id,
    name: user.name,
    phone: user.phone,
    email: user.email,
    addresses: user.addresses || [],
  });
});

router.put(
  '/me',
  requireAuth,
  [
    body('name').trim().isLength({ min: 2 }).withMessage('Name is required'),
    body('email').optional().isEmail().withMessage('Invalid email'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation error', errors: errors.array() });
    }

    const { name, email } = req.body;
    const user = await User.findByIdAndUpdate(
      req.user.userId,
      { name, email: email || '' },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({
      id: user._id,
      name: user.name,
      phone: user.phone,
      email: user.email,
      addresses: user.addresses || [],
    });
  }
);

router.post(
  '/me/addresses',
  requireAuth,
  [
    body('street').trim().notEmpty().withMessage('Street is required'),
    body('building').trim().notEmpty().withMessage('Building is required'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation error', errors: errors.array() });
    }

    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const address = {
      label: req.body.label || '',
      city: req.body.city || '',
      street: req.body.street,
      building: req.body.building,
      apartment: req.body.apartment || '',
      comment: req.body.comment || '',
      isDefault: Boolean(req.body.isDefault),
    };

    if (address.isDefault) {
      user.addresses.forEach((item) => {
        item.isDefault = false;
      });
    }

    user.addresses.push(address);
    await user.save();

    res.status(201).json({ addresses: user.addresses });
  }
);

router.put(
  '/me/addresses/:id',
  requireAuth,
  [
    body('street').trim().notEmpty().withMessage('Street is required'),
    body('building').trim().notEmpty().withMessage('Building is required'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation error', errors: errors.array() });
    }

    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const address = user.addresses.id(req.params.id);
    if (!address) {
      return res.status(404).json({ message: 'Address not found' });
    }

    const isDefault = Boolean(req.body.isDefault);
    if (isDefault) {
      user.addresses.forEach((item) => {
        item.isDefault = false;
      });
    }

    address.label = req.body.label || '';
    address.city = req.body.city || '';
    address.street = req.body.street;
    address.building = req.body.building;
    address.apartment = req.body.apartment || '';
    address.comment = req.body.comment || '';
    address.isDefault = isDefault;

    await user.save();

    res.json({ addresses: user.addresses });
  }
);

router.delete('/me/addresses/:id', requireAuth, async (req, res) => {
  const user = await User.findById(req.user.userId);
  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }

  const address = user.addresses.id(req.params.id);
  if (!address) {
    return res.status(404).json({ message: 'Address not found' });
  }

  address.deleteOne();
  await user.save();

  res.json({ addresses: user.addresses });
});

module.exports = router;
