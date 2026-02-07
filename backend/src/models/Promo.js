const mongoose = require('mongoose');

const PromoSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    subtitle: { type: String, default: '' },
    badge: { type: String, default: '' },
    imageUrl: { type: String, default: '' },
    discountPercent: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Promo', PromoSchema);
