const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');

const User = require('../models/User');

const router = express.Router();

router.post(
  '/register',
  [
    body('name').trim().isLength({ min: 2 }).withMessage('Name is required'),
    body('phone').trim().isLength({ min: 8 }).withMessage('Phone is required'),
    body('email').optional({ checkFalsy: true }).isEmail().withMessage('Invalid email'),
    body('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 chars')
      .matches(/[A-Za-z]/)
      .withMessage('Password must contain a letter')
      .matches(/[0-9]/)
      .withMessage('Password must contain a number'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation error', errors: errors.array() });
    }

    try {
      const { name, phone, email, password } = req.body;

      const existing = await User.findOne({ phone });
      if (existing) {
        return res.status(409).json({ message: 'User already exists' });
      }

      const passwordHash = await bcrypt.hash(password, 10);
      const user = await User.create({
        name,
        phone,
        email: email || '',
        passwordHash,
      });

      const token = jwt.sign(
        { userId: user._id, phone: user.phone, name: user.name },
        process.env.JWT_SECRET || 'orderby_secret',
        { expiresIn: '7d' }
      );

      return res.status(201).json({
        token,
        user: {
          id: user._id,
          name: user.name,
          phone: user.phone,
          email: user.email,
        },
      });
    } catch (error) {
      if (error.code === 11000) {
        return res.status(409).json({ message: 'User already exists' });
      }
      console.error('Register error:', error);
      return res.status(500).json({ message: error.message || 'Internal server error' });
    }
  }
);

router.post(
  '/login',
  [
    body('phone').trim().isLength({ min: 8 }).withMessage('Phone is required'),
    body('password')
      .isLength({ min: 8 })
      .withMessage('Password is required'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ message: 'Validation error', errors: errors.array() });
    }

    const { phone, password } = req.body;

    const user = await User.findOne({ phone });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const match = await bcrypt.compare(password, user.passwordHash);
    if (!match) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { userId: user._id, phone: user.phone, name: user.name },
      process.env.JWT_SECRET || 'orderby_secret',
      { expiresIn: '7d' }
    );

    return res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        phone: user.phone,
        email: user.email,
      },
    });
  }
);

module.exports = router;
