const mongoose = require('mongoose');

const CouponSchema = new mongoose.Schema(
  {
    code: { type: String, required: true, trim: true, unique: true },
    description: { type: String, default: '' },
    discountPercent: { type: Number, default: 0 },
    discountAmount: { type: Number, default: 0 },
    minOrder: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Coupon', CouponSchema);
